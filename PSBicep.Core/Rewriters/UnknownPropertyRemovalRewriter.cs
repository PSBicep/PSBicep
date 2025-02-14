using System.Collections.Generic;
using System.Linq;
using Bicep.Core.Extensions;
using Bicep.Core.Parsing;
using Bicep.Core.Semantics;
using Bicep.Core.Syntax;
using Bicep.Core.TypeSystem.Types;

namespace PSBicep.Core.Rewriters
{
    // Removes any object properties which is not found in the schema or marked as fallback property
    public class UnknownPropertyRemovalRewriter : SyntaxRewriteVisitor
    {
        private readonly SemanticModel semanticModel;

        public UnknownPropertyRemovalRewriter(SemanticModel semanticModel)
        {
            this.semanticModel = semanticModel;
        }

        protected override SyntaxBase ReplaceObjectSyntax(ObjectSyntax syntax)
        {
            var declaredType = semanticModel.GetDeclaredType(syntax);
            if (declaredType is not ObjectType objectType)
            {
                return base.ReplaceObjectSyntax(syntax);
            }

            var newChildren = new List<SyntaxBase>();
            foreach (var child in syntax.Children)
            {
                if (child is ObjectPropertySyntax objectProperty)
                {
                    if (objectProperty.TryGetKeyText() is string propertyKey)
                    {
                        if (objectType.Properties.TryGetValue(propertyKey) is { } propertyValue)
                        {
                            if (propertyValue.Flags.HasFlag(TypePropertyFlags.FallbackProperty))
                            {
                                // Property is marked as fallback property, remove it
                                continue;
                            }
                        }
                        else
                        {
                            // Property is not found in the schema, remove it
                            continue;
                        }
                    }
                }

                if (child is Token { Type: TokenType.NewLine } &&
                    newChildren.LastOrDefault() is Token { Type: TokenType.NewLine })
                {
                    // collapse blank lines
                    continue;
                }

                newChildren.Add(Rewrite(child));
            }

            if (Enumerable.SequenceEqual(newChildren, syntax.Children))
            {
                return base.ReplaceObjectSyntax(syntax);
            }

            return new ObjectSyntax(
                syntax.OpenBrace,
                newChildren,
                syntax.CloseBrace);
        }
    }
}
